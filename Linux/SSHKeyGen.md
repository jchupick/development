## SSH KeyGen and Upload to Server

  1. Generate Key:  
    ```ssh-keygen -t rsa -b 2048```
    Indicate public/private keypair filename
  1. Upload  
    ```ssh-copy-id -i <private_keyfile_from_step_1> username@servername```
