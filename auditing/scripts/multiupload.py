import threading
import boto3
import os
import sys 
from boto3.s3.transfer import TransferConfig
from datetime import datetime

BUCKET_NAME = "chc-multipart"

def multi_part_upload_with_s3():
    # Multipart upload
    s3 = boto3.resource('s3')
    config = TransferConfig(multipart_threshold=1024, max_concurrency=10, multipart_chunksize=1024 * 100, use_threads=True)
    file_path = '/Users/sswarnde/work/test/myfile1g.bin'
    key_path = 'myfile.bin'
    s3.meta.client.upload_file(file_path, BUCKET_NAME, key_path,  Config=config, Callback=ProgressPercentage(file_path))                            
    # , ExtraArgs={'ACL': 'public-read', 'ContentType': 'text/pdf'}


class ProgressPercentage(object):
    def __init__(self, filename):
        self._filename = filename
        self._size = float(os.path.getsize(filename))
        self._seen_so_far = 0
        self._lock = threading.Lock()
        
    def __call__(self, bytes_amount):
        # To simplify we'll assume this is hooked up
        # to a single filename.
        with self._lock:
            self._seen_so_far += bytes_amount
            percentage = (self._seen_so_far / self._size) * 100
            sys.stdout.write(
                "\r%s  %s / %s  (%.2f%%)" % (
                    self._filename, self._seen_so_far, self._size,
                    percentage))
            sys.stdout.flush()

#Let’s now add a main method to call our multi_part_upload_with_s3:

def main():
    now = datetime.now()
    current_time = now.strftime("%H:%M:%S")
    print("Current Time =", current_time)

    multi_part_upload_with_s3()

    now = datetime.now()
    current_time = now.strftime("%H:%M:%S")
    print("Current Time =", current_time)

if __name__ == '__main__': 
    main()