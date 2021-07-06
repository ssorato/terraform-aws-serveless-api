import json
import boto3
from datetime import datetime


def lambda_handler(event, context):
    # Instanciating connection objects with DynamoDB
    dynamodb = boto3.resource('dynamodb')
    client = boto3.client('dynamodb')

    tableTemperature = dynamodb.Table('Temperatures')

    eventDateTime = (datetime.now()).strftime("%Y-%m-%d %H:%M:%S")
    deviceId = event['deviceId']
    temperature = event['temperature']

    try:

        tableTemperature.put_item(
            Item={
                'eventDateTime': eventDateTime,
                'deviceId': deviceId,
                'temperature': int(temperature)
            }
        )

        return {
            'statusCode': 200,
            'body': json.dumps('Succesfully inserted temperature!')
        }
    except:
        print('Closing lambda function')
        return {
            'statusCode': 400,
            'body': json.dumps('Error saving the temperature')
        }

