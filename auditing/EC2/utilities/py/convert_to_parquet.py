# pandas
# pyarrow

import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
import s3fs

def fn_extractdat():
    df=pd.read_csv('c:\ekam\out.csv', sep='\t')
    pq.write_to_dataset(pa.Table.from_pandas(df),'c:\ekam\out.parquet',  partition_cols=['server_instance_name'])

    #df.to_parquet('c:\ekam\out.parquet',compression='gzip', partition_col=['server_instance_name'])
    #table = pa.Table.from_pandas(df,preserve_index=False) 
    #pq.write_table(table,'c:\ekam\out.parquet')


def main():
    fn_extractdat()

main()
