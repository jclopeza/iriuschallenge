import boto3
import json
from botocore.exceptions import NoCredentialsError, ClientError
from datetime import datetime

class S3Uploader:
    def __init__(self, aws_access_key_id, aws_secret_access_key, region_name="eu-west-3"):
        self.s3_client = boto3.client(
            "s3",
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            region_name=region_name
        )

    def upload_json_to_s3(self, data, bucket_name="irius-challenge-public-bucket"):
        """
            Upload a JSON file to S3.

            :param data: JSON dictionary to be uploaded to S3.
            :param bucket_name: Name of the S3 bucket.
            :return: Public URL of the file in S3 or an error message.
        """
        try:
            filename = f"{int(datetime.now().timestamp())}.json"
            # Convert the JSON dictionary to a JSON string
            json_data = json.dumps(data)

            # Upload the JSON file to S3
            self.s3_client.put_object(
                Bucket=bucket_name,
                Key=filename,
                Body=json_data,
                ContentType="application/json"
            )

            # Generate the file URL in S3
            url = f"https://{bucket_name}.s3.amazonaws.com/{filename}"
            return url

        except NoCredentialsError:
            return "Error: Credentials not found."
        except ClientError as e:
            return f"Error uploading to S3: {e}"