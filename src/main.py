from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from utils.word_counter import count_frequent_words
from utils.s3_uploader import S3Uploader
import os

from fastapi import FastAPI
import uvicorn

app = FastAPI()

# Define the input data model for the request
class TextData(BaseModel):
    data: str

@app.post("/frequent-words/")
async def get_frequent_words(text_data: TextData):
    # Check that the "data" field is not empty
    if not text_data.data:
        raise HTTPException(status_code=400, detail="The 'data' parameter cannot be empty")
    
    # Call the function from the module to count the words
    data = count_frequent_words(text_data.data)
    uploader = S3Uploader(os.getenv("AWS_ACCESS_KEY_ID"), os.getenv("AWS_SECRET_ACCESS_KEY"), os.getenv("AWS_REGION"))
    url = uploader.upload_json_to_s3(data=data)
    
    return {"url": url}


if __name__ == '__main__':
    uvicorn.run(app, host='127.0.0.1', port=8000)