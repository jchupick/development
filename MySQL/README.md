##
'''
SELECT TABLE_SCHEMA,TABLE_NAME,CAST((data_length+index_length)/power(1024,3) AS DECIMAL(6,2)) GB FROM information_schema.tables ORDER BY GB;
'''
