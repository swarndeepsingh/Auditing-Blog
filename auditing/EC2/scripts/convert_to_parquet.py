# pandas
# pyarrow

import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
import sys

try:
    inputpath = sys.argv[1]
    outputpath = sys.argv[2]
except:
    print("Python Error, cannot read arguments:")
    print(sys.exc_info())
    sys.exit()



def fn_extractdat(i, o):
    sys.argv
    print (len(sys.argv))
    if(len(sys.argv) < 3):
        print("Error - parameters missing")
        
    else:
        
        try:
            df=pd.read_csv(i, sep='\t')
            pq.write_to_dataset(pa.Table.from_pandas(df),o,  partition_cols=['server_instance_name'])
        except:
            print("Python Error, failed to convert csv to parquet:")
            print(sys.exc_info())
            sys.exit()


        #df.to_parquet('c:\ekam\out.parquet',compression='gzip', partition_col=['server_instance_name'])
        #table = pa.Table.from_pandas(df,preserve_index=False) 
        #pq.write_table(table,'c:\ekam\out.parquet')


def main():
    fn_extractdat (inputpath, outputpath)

main()
