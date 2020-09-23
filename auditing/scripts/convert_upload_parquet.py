
import boto3
import pandas as pd
import s3parq as parq
import sys, json
import io






def fn_extractdat(s3bucket, s3inputfolder):
    if(len(sys.argv) < 2):
        print("Error - parameters missing")
        return

        
    else:
        s3_resource = boto3.resource('s3')
        s3_client = boto3.client('s3')
        s3_bucket = s3_resource.Bucket(s3bucket)

        #print("checked s3 bucket")
        
        try:
            for s3_object in s3_bucket.objects.filter(Prefix=s3inputfolder):
                #print(s3_object.key)
                s3_key = s3_object.key
                if (s3_key[-1] != '/'):
                    s3_file =s3_client.get_object(Bucket=s3bucket, Key=s3_key)
                    s3_file_r =s3_resource.Object(s3bucket, s3_key)
                    body = s3_file['Body']
                    csv_string = body.read().decode('utf-8')
                    df = pd.read_csv(io.StringIO(csv_string),delim_whitespace=True)
                    parq.publish(bucket=s3bucket, dataframe=df, key='data', partitions=['server_instance_name'])
                    s3_file_r.delete()
                    return
                    
                
        except:
            print("Python Error, failed to convert csv to parquet:")
            print(sys.exc_info())
            sys.exit()
            

def main():
    try:
        s3bucket = 'auditsql'
        s3inputfolder = 'rawdata'

    except:
        print("Python Error, cannot read arguments:")
        print(sys.exc_info())
        sys.exit()

    fn_extractdat (s3bucket, s3inputfolder)

main()
