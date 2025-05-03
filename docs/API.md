# RingAI Agents API Documentation

## Overview

The RingAI Agents API provides a comprehensive HTTP interface for managing AI agents, teams, tasks, and system monitoring. The API is built using Ring's HTTPLib and follows RESTful principles.

## Base URL

```
http://localhost:8080
```

## Authentication

All API requests require authentication using JWT tokens. Include the token in the Authorization header:

```
Authorization: Bearer <token>
```

## Endpoints

### Agents

#### List Agents
```http
GET /agents
```

Response:
```json
{
    "status": "success",
    "agents": [
        {
            "id": 1,
            "name": "Agent1",
            "role": "Developer",
            "skills": ["JavaScript", "Python"],
            "personality": {
                "openness": 80,
                "conscientiousness": 85,
                "extraversion": 70,
                "agreeableness": 75,
                "neuroticism": 30
            }
        }
    ]
}
```

#### Create Agent
```http
POST /agents/add
```

Request Body:
```json
{
    "name": "Agent1",
    "role": "Developer",
    "goal": "Deliver high-quality code",
    "skills": "JavaScript,Python,React",
    "openness": 80,
    "conscientiousness": 85,
    "extraversion": 70,
    "agreeableness": 75,
    "neuroticism": 30,
    "language_model": "gemini-1.5-flash"
}
```

#### Get Agent
```http
GET /agents/{id}
```

#### Update Agent
```http
PUT /agents/{id}
```

#### Delete Agent
```http
DELETE /agents/{id}
```

#### Train Agent
```http
POST /agents/{id}/train
```

### Teams

#### List Teams
```http
GET /teams
```

#### Create Team
```http
POST /teams/add
```

Request Body:
```json
{
    "name": "Development Team",
    "objective": "Deliver project milestones",
    "leader_id": 1,
    "member_ids": [2, 3, 4]
}
```

#### Get Team
```http
GET /teams/{id}
```

#### Update Team
```http
PUT /teams/{id}
```

#### Delete Team
```http
DELETE /teams/{id}
```

#### Add Team Member
```http
POST /teams/{id}/members
```

#### Remove Team Member
```http
DELETE /teams/{id}/members/{member_id}
```

### Tasks

#### List Tasks
```http
GET /tasks
```

#### Create Task
```http
POST /tasks/add
```

Request Body:
```json
{
    "title": "Implement Feature",
    "description": "Create new authentication system",
    "priority": 8,
    "context": "Security",
    "subtasks": [
        "Design database schema",
        "Implement API endpoints"
    ],
    "agent_id": 1
}
```

#### Get Task
```http
GET /tasks/{id}
```

#### Update Task
```http
PUT /tasks/{id}
```

#### Delete Task
```http
DELETE /tasks/{id}
```

#### Add Subtask
```http
POST /tasks/{id}/subtasks
```

#### Update Progress
```http
PUT /tasks/{id}/progress
```

### AI Interactions

#### Chat with AI
```http
POST /ai/chat
```

Request Body:
```json
{
    "prompt": "Explain the concept of recursion",
    "parameters": {
        "temperature": 0.7,
        "max_tokens": 1000,
        "format": "markdown"
    }
}
```

#### Analyze Data
```http
POST /ai/analyze
```

#### Train Model
```http
POST /ai/learn
```

### Monitoring

#### Get Metrics
```http
GET /monitor/metrics
```

Response:
```json
{
    "status": "success",
    "metrics": {
        "cpu_usage": 45,
        "memory_usage": 512,
        "active_sessions": 10,
        "task_completion_rate": 85,
        "agent_performance": {
            "average": 92,
            "by_agent": {
                "1": 95,
                "2": 88
            }
        }
    }
}
```

#### Get Performance
```http
GET /monitor/performance
```

#### Get Events
```http
GET /monitor/events
```

#### Configure Alerts
```http
POST /monitor/alerts
```

## Error Handling

The API uses standard HTTP status codes and returns detailed error messages in JSON format:

```json
{
    "status": "error",
    "message": "Error description",
    "code": "ERROR_CODE"
}
```

Common Error Codes:
- `AUTH_ERROR`: Authentication error
- `INVALID_INPUT`: Invalid input parameters
- `NOT_FOUND`: Resource not found
- `SERVER_ERROR`: Internal server error

## Rate Limiting

The API implements rate limiting to ensure system stability:
- 100 requests per minute per IP
- 1000 requests per hour per user

Rate limit headers:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1582134520
```

## WebSocket Support

Real-time updates are available through WebSocket connections:

```javascript
ws://localhost:8080/ws
```

Events:
- `agent_update`: Agent status changes
- `task_update`: Task progress updates
- `team_update`: Team changes
- `system_alert`: System notifications

## Examples

### Create and Train Agent
```ring
# Create agent
oHttp = new HTTPClient
oHttp.setURL("http://localhost:8080/agents/add")
oHttp.setHeader("Content-Type", "application/json")
oHttp.setHeader("Authorization", "Bearer " + cToken)

cResponse = oHttp.post('{
    "name": "AI Developer",
    "role": "Backend Developer",
    "skills": "Ring,Python,AI",
    "goal": "Develop efficient algorithms"
}')

# Train agent
if JSON2LIST(cResponse)[:status] = "success" {
    nAgentId = JSON2LIST(cResponse)[:id]
    oHttp.setURL("http://localhost:8080/agents/" + nAgentId + "/train")
    oHttp.post('{
        "topics": ["algorithms", "data structures"],
        "duration": 3600
    }')
}
```

### Create Team and Assign Task
```ring
# Create team
oHttp = new HTTPClient
cTeamResponse = oHttp.post("http://localhost:8080/teams/add", '{
    "name": "AI Team",
    "objective": "Develop AI features",
    "leader_id": 1,
    "member_ids": [2, 3]
}')

# Create and assign task
if JSON2LIST(cTeamResponse)[:status] = "success" {
    nTeamId = JSON2LIST(cTeamResponse)[:id]
    oHttp.post("http://localhost:8080/tasks/add", '{
        "title": "Implement AI Feature",
        "description": "Add new AI capabilities",
        "priority": 9,
        "team_id": ' + nTeamId + '
    }')
}
```

## Security Considerations

1. API Authentication
   - Use HTTPS for all requests
   - Implement token expiration
   - Use secure token storage

2. Input Validation
   - Validate all input parameters
   - Sanitize user input
   - Implement request size limits

3. Rate Limiting
   - Prevent abuse
   - Ensure fair usage
   - Protect system resources

4. Error Handling
   - Never expose internal errors
   - Log all errors securely
   - Provide helpful error messages

## Best Practices

1. API Usage
   - Use appropriate HTTP methods
   - Include proper headers
   - Handle rate limits gracefully

2. Performance
   - Minimize request payload size
   - Use caching when appropriate
   - Implement pagination

3. Error Handling
   - Always check response status
   - Implement proper error recovery
   - Log API interactions

4. Security
   - Store tokens securely
   - Implement proper logout
   - Use HTTPS for all requests
