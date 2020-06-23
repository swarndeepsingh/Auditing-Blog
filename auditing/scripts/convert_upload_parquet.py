

import pandas as pd
import s3parq as parq
import sys

try:
    inputpath = sys.argv[1]
    s3bucket = sys.argv[2]
except:
    print("Python Error, cannot read arguments:")
    print(sys.exc_info())
    sys.exit()



def fn_extractdat(i):
    if(len(sys.argv) < 2):
        print("Error - parameters missing")
        
    else:
        
        try:
            df=pd.read_csv(i, sep='\t')
            parq.publish(bucket=s3bucket, dataframe=df, key='data', partitions=['server_instance_name'])
        except:
            print("Python Error, failed to convert csv to parquet:")
            print(sys.exc_info())
            sys.exit()



def main():
    fn_extractdat (inputpath)

main()
