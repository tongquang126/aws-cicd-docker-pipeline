# AWS CI/CD Docker Pipeline

A complete AWS-native CI/CD pipeline that automatically builds and deploys Docker applications using GitHub webhooks, CodePipeline, CodeBuild, and ECR.

## 🚀 Features

- **Self-Mutating Pipeline**: Automatically updates itself when `pipeline.yaml` changes
- **Multi-Branch Support**: Switch between branches (main, develop, feature) via parameter updates
- **Docker Integration**: Builds and pushes Docker images to Amazon ECR
- **GitHub Webhook**: Automatic triggering on code pushes
- **Code Quality**: GitHub Actions for Black, isort, and flake8 checks
- **Infrastructure as Code**: Complete CloudFormation template

## 🏗️ Architecture

```
GitHub Push → Webhook → CodePipeline → [UpdatePipeline] → [Build] → ECR
                                           ↓
                                    CloudFormation Stack Update
```

### Components

- **CodePipeline**: Orchestrates the CI/CD workflow
- **CodeBuild**: Builds Docker images using `buildspec.yml`
- **ECR**: Stores Docker images with commit-based tags
- **S3**: Artifact storage for pipeline stages
- **CloudFormation**: Self-mutating infrastructure updates
- **GitHub Actions**: Code quality checks (Black, flake8, isort)

## 📁 Project Structure

```
├── app/                     # Flask application
│   ├── app.py              # Main Flask app
│   └── requirements.txt    # Production dependencies
├── .github/
│   └── workflows/
│       └── ci.yml          # Code quality checks
├── Dockerfile              # Multi-stage Docker build
├── buildspec.yml           # CodeBuild configuration
├── pipeline.yaml           # CloudFormation template
├── requirements-dev.txt    # Development dependencies
└── README.md
```

## 🛠️ Setup Instructions

### Prerequisites

- AWS CLI configured with appropriate permissions
- GitHub Personal Access Token
- ECR repository created

### 1. Store GitHub Token in SSM

```bash
aws ssm put-parameter \
  --name "/github/pat/pipeline" \
  --value "your-github-token" \
  --type "String" \
  --description "GitHub PAT for CodePipeline"
```

### 2. Deploy the Pipeline

```bash
aws cloudformation deploy \
  --stack-name aws-cicd-docker-pipeline \
  --template-file pipeline.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    GitHubOwner=tongquang126 \
    GitHubRepo=aws-cicd-docker-pipeline \
    GitHubBranch=main \
    GitHubOAuthToken=/github/pat/pipeline \
    EcrRepositoryUri=YOUR_ECR_REPO_URI
```

### 3. Verify Deployment

Check the pipeline URL in CloudFormation outputs:

```bash
aws cloudformation describe-stacks \
  --stack-name aws-cicd-docker-pipeline \
  --query 'Stacks[0].Outputs[?OutputKey==`PipelineUrl`].OutputValue' \
  --output text
```

## 🔄 Self-Mutating Pipeline

The pipeline can update itself automatically when `pipeline.yaml` changes:

1. **UpdatePipeline Stage**: Runs CloudFormation deploy with the latest template
2. **Build Stage**: Continues with Docker build and ECR push

This means you only need to deploy the stack manually once. All future infrastructure changes are handled automatically via git commits.

## 🌿 Multi-Branch Support

Switch the monitored branch by updating the CloudFormation parameter:

```bash
aws cloudformation update-stack \
  --stack-name aws-cicd-docker-pipeline \
  --use-previous-template \
  --parameters \
    ParameterKey=GitHubBranch,ParameterValue=develop \
    ParameterKey=GitHubOwner,UsePreviousValue=true \
    ParameterKey=GitHubRepo,UsePreviousValue=true \
    ParameterKey=GitHubOAuthToken,UsePreviousValue=true \
    ParameterKey=EcrRepositoryUri,UsePreviousValue=true
```

**Note**: Only one branch can be monitored at a time. The webhook will automatically update to listen to the new branch.

## 💻 Local Development

### Setup Development Environment

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r app/requirements.txt -r requirements-dev.txt
```

### Code Quality Checks

```bash
# Format code
black app/
isort app/

# Check code quality
flake8 app/
```

### Run Flask App Locally

```bash
cd app
python app.py
# Visit http://localhost:5000
```

### Build Docker Image Locally

```bash
docker build -t aws-cicd-docker-pipeline .
docker run -p 5000:5000 aws-cicd-docker-pipeline
```

## 🔧 Configuration

### Environment Variables (CodeBuild)

- `ECR_REPO_URI`: Target ECR repository URI
- `AWS_DEFAULT_REGION`: AWS region (auto-set by CodeBuild)
- `CODEBUILD_RESOLVED_SOURCE_VERSION`: Git commit hash (auto-set)

### Docker Image Tagging

Images are tagged with:
- **Commit hash**: First 7 characters of git commit
- **Latest**: Only for main branch builds

Example: `123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:abc1234`

## 🚦 GitHub Actions

The repository includes automated code quality checks that run on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches

Checks include:
- **Black**: Code formatting
- **isort**: Import sorting
- **flake8**: Linting and code style

## 📊 Monitoring

### Pipeline Status

- **AWS Console**: Check CodePipeline executions
- **CloudWatch Logs**: CodeBuild execution logs
- **ECR Console**: View pushed Docker images

### Troubleshooting

Common issues and solutions:

1. **YAML_FILE_ERROR in buildspec.yml**: Check for blank lines between commands
2. **Docker Hub rate limit**: Using Amazon ECR Public Gallery images
3. **GitHub webhook not triggering**: Verify GitHub token permissions
4. **ECR push permissions**: Check CodeBuild IAM role permissions

## 🔒 Security Considerations

- **IAM Roles**: Principle of least privilege
- **GitHub Token**: Stored as SSM String parameter (not SecureString due to CodePipeline v1 limitations)
- **CloudFormation Role**: Has AdministratorAccess for self-mutating capability
- **ECR Images**: Scanned for vulnerabilities

## 📝 License

This project is licensed under the MIT License.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Ensure code quality checks pass
5. Submit a pull request

The GitHub Actions CI will automatically run code quality checks on your PR.
