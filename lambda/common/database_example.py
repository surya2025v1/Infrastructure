"""
Example Lambda function showing how to connect to MySQL RDS
using AWS Secrets Manager for all DB connection info.
"""

import os
import json
import boto3
import pymysql
from typing import Dict, Any

def get_db_info(secret_arn):
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId=secret_arn)
    secret = response['SecretString']
    info = json.loads(secret)
    return info

def get_db_connection():
    secret_arn = os.environ['DB_CREDENTIALS_SECRET_ARN']
    info = get_db_info(secret_arn)
    connection = pymysql.connect(
        host=info['host'],
        port=int(info.get('port', 3306)),
        user=info['username'],
        password=info['password'],
        database=info['dbname'],
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor
    )
    return connection

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    try:
        connection = get_db_connection()
        with connection.cursor() as cursor:
            cursor.execute("SELECT VERSION() as version")
            result = cursor.fetchone()
        connection.close()
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Successfully connected to MySQL',
                'mysql_version': result['version'],
                'db_host': os.environ.get('DB_CREDENTIALS_SECRET_ARN'),
                'db_info': True
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

# Example of how to use in FastAPI
"""
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse

app = FastAPI()

@app.get("/health")
async def health_check():
    try:
        connection = get_db_connection()
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1 as health")
            result = cursor.fetchone()
        connection.close()
        
        return JSONResponse(content={
            "status": "healthy",
            "database": "connected",
            "mysql_version": result['health']
        })
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")

@app.get("/users")
async def get_users():
    try:
        connection = get_db_connection()
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM users LIMIT 10")
            users = cursor.fetchall()
        connection.close()
        
        return JSONResponse(content={"users": users})
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch users: {str(e)}")
""" 