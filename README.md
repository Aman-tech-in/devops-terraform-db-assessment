# DevOps Assessment – Terraform + Database Reliability

This repository implements the requested assessment with Terraform, AWS ECS/Fargate + ALB + RDS design, Docker Compose PostgreSQL, seed/migration SQL, backup/restore scripts, and GitHub Actions.

## Architecture

`Internet -> Application Load Balancer -> ECS/Fargate -> PostgreSQL RDS`

The network module creates one VPC, two public subnets, two private subnets across two AZs, an internet gateway, NAT gateway(s), and three security groups. The ECS tasks and RDS instance are private. ALB is public. RDS ingress on TCP/5432 is restricted to the ECS security group.

## Environment differences

| Setting | dev | prod |
|---|---:|---:|
| ECS desired count | 1 | 2 |
| ECS task size | 256 CPU / 512 MiB | 512 CPU / 1024 MiB |
| NAT gateways | 1 | 2 |
| RDS class | db.t3.micro | db.t3.medium |
| RDS storage | 20 GiB | 50 GiB |
| Max storage | 50 GiB | 200 GiB |
| Backup retention | 3 days | 14 days |
| Multi-AZ | false | true |
| Deletion protection | false | true |
| Skip final snapshot | true | false |

## Windows prerequisites

Install Git for Windows, Docker Desktop, Terraform, and VS Code. Docker Desktop's WSL 2 backend is recommended on Windows.

Verify:

```powershell
git --version
docker --version
docker compose version
terraform version
```

## Local database

1. Copy `.env.example` to `.env`.
2. From Git Bash or PowerShell, run:

```bash
docker compose up -d
```

The PostgreSQL image initializes the schema, indexes, and 200 seed bookings plus booking events on first startup.

Check status:

```bash
docker compose ps
```

Verify data:

```bash
docker compose exec db psql -U app_user -d booking_db -c "SELECT COUNT(*) FROM hotel_bookings;"
docker compose exec db psql -U app_user -d booking_db -c "SELECT COUNT(*) FROM booking_events;"
```

Run the verification SQL:

```bash
docker compose exec -T db psql -U app_user -d booking_db -f /docker-entrypoint-initdb.d/004_verification.sql
```

## Query optimization

The target query is:

```sql
SELECT org_id, status, COUNT(*), SUM(amount)
FROM hotel_bookings
WHERE city = 'delhi'
  AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY org_id, status;
```

The index is:

```sql
CREATE INDEX idx_hotel_bookings_city_created_at
    ON hotel_bookings (city, created_at)
    INCLUDE (org_id, status, amount);
```

`city` and `created_at` are the filter columns, so they are the leading index columns. `org_id`, `status`, and `amount` are included to let PostgreSQL consider an index-only scan and avoid unnecessary heap access when the visibility map permits it.

Run the query plan:

```bash
docker compose exec db psql -U app_user -d booking_db -c "EXPLAIN (ANALYZE, BUFFERS) SELECT org_id, status, COUNT(*), SUM(amount) FROM hotel_bookings WHERE city = 'delhi' AND created_at >= NOW() - INTERVAL '30 days' GROUP BY org_id, status;"
```

Because the seed dataset is intentionally small, the optimizer may still choose a sequential scan. The important part of the assessment is that the index matches the access pattern and the reasoning is documented.

## Backup

Run from Git Bash (the scripts use Bash):

```bash
./scripts/backup.sh
```

A timestamped SQL dump appears under `backups/`. Backup files are ignored by Git.

## Restore

Restore to a fresh database named `booking_db_restore`:

```bash
./scripts/restore.sh backups/booking_db_<timestamp>.sql
```

The script drops and recreates the restore database, loads the dump, and prints row counts for both tables.

## Terraform validation

### Dev

```powershell
cd infra\envs\dev
terraform fmt -check -recursive ..\..\
terraform init
terraform validate
terraform plan -refresh=false
```

### Prod

```powershell
cd ..\prod
terraform fmt -check -recursive ..\..\
terraform init
terraform validate
terraform plan -refresh=false
```

The environment tfvars files set `plan_only = true`, allowing plan review without real AWS credentials. The AWS region is passed directly into modules, so the plan does not need an AWS availability-zone or region data lookup. This repository does not attempt to deploy AWS resources as part of the assessment. For a real deployment, set `plan_only = false` and configure AWS credentials using your normal credential chain.

`terraform init` will generate `.terraform.lock.hcl`; commit that lock file to the repository.

## Terraform plan review checklist

Confirm the plan includes:

- VPC, internet gateway, two public and two private subnets.
- NAT gateway(s) and private routing.
- ALB in public subnets.
- ECS cluster, task definition and Fargate service in private subnets.
- ECS execution IAM role and CloudWatch log group.
- RDS subnet group and private PostgreSQL instance.
- ALB -> ECS security group access on TCP/80.
- ECS -> RDS security group access on TCP/5432.
- RDS `publicly_accessible = false`.
- Dev/prod sizing and backup/deletion settings differ.

## GitHub Actions

`.github/workflows/terraform.yml` runs on pushes to `main` and pull requests touching `infra/`. It performs recursive format checking, `terraform init`, `terraform validate`, and `terraform plan -refresh=false` for both dev and prod. Each plan is uploaded as a workflow artifact.

## GitHub submission

```bash
git init
git branch -M main
git add .
git commit -m "Complete Terraform and database reliability assessment"
git remote add origin https://github.com/<YOUR-USERNAME>/<YOUR-REPO>.git
git push -u origin main
```

Do not commit `.env`, Terraform state files, real AWS credentials, or database dumps.
