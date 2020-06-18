import threadingimport boto3
import os
import sysfrom boto3.s3.transfer import TransferConfigBUCKET_NAME = "YOUR_BUCKET_NAME"def multi_part_upload_with_s3():
    # Multipart upload
    config = TransferConfig(multipart_threshold=1024 * 25, max_concurrency=10,
                            multipart_chunksize=1024 * 25, use_threads=True)
    file_path = os.path.dirname(__file__) + '/largefile.pdf'
    key_path = 'multipart_files/largefile.pdf'
    s3.meta.client.upload_file(file_path, BUCKET_NAME, key_path,
                            ExtraArgs={'ACL': 'public-read', 'ContentType': 'text/pdf'},
                            Config=config,
                            Callback=ProgressPercentage(file_path)
                            )class ProgressPercentage(object):
    def __init__(self, filename):
        self._filename = filename
        self._size = float(os.path.getsize(filename))
        self._seen_so_far = 0
        self._lock = threading.Lock()def __call__(self, bytes_amount):
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

if __name__ == '__main__': 
multi_part_upload_with_s3()