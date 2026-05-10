
# vllm build


- [offical vllm build guide](https://docs.vllm.ai/en/latest/getting_started/installation/gpu/index.html)

## env

- gcc11.4.0,cuda12.8
- conda env: python3.11,torch
- vllm src: 0.19.2rc1.dev212+g8cd174fa3.d20260427 - build on 26.4.26(commit id 8cd174fa358326d5cc4195446be2ebcd65c481ce)


## build details

### build clib isolute

```
cmake -G Ninja \
  -DFETCHCONTENT_BASE_DIR=../.deps \
  -DVLLM_PYTHON_EXECUTABLE=$(which python3) \
  -DCMAKE_INSTALL_PREFIX=.. \
  -DCMAKE_BUILD_TYPE=ReleaseWithDebInfo \
  -DVLLM_TARGET_DEVICE=cuda \
  -DNVCC_THREADS=4 \
  ..
#cmake --build . -j $(nproc)
cmake --build . -j8
```

### build python lib
```
# --no-build-isolation  mean use current python environment
python -m pip install --no-build-isolation -e . -i https://pypi.tuna.tsinghua.edu.cn/simple 
```

### build by script
```

export http_proxy=http://127.0.0.1:10808
export https_proxy=http://127.0.0.1:10808
export HTTP_PROXY=http://127.0.0.1:10808
export HTTPS_PROXY=http://127.0.0.1:10808

nohup bash ./build.sh > build.log 2>&1 &
```

## some problem record

### crash unexpected - out off memory because of job number is too large

when run the following command with env will crash without output error information.

it is hard to analysis because the process terminate unexpected without any output.

try to only build clib by cmake and find nvcc exit 255 which is caused by limination of mem

the default setup.py will use max threads to compile and that is why it always crash.

env
```
/home/aidroid/.local/bin/uv
uv 0.11.7 (x86_64-unknown-linux-gnu)
/home/aidroid/.conda/envs/vllm/bin/python
/home/aidroid/.conda/envs/vllm/bin/pip
Python 3.13.13
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2025 NVIDIA Corporation
Built on Wed_Jan_15_19:20:09_PST_2025
Cuda compilation tools, release 12.8, V12.8.61
Build cuda_12.8.r12.8/compiler.35404655_0
Requirement already satisfied: pip in /home/aidroid/.local/lib/python3.13/site-packages (26.0.1)

```


### missing setuptools_scm

```
  
  × Preparing editable metadata (pyproject.toml) did not run successfully.
  │ exit code: 1
  ╰─> [18 lines of output]
      Traceback (most recent call last):
        File "/home/aidroid/.conda/envs/vllm/lib/python3.11/site-packages/pip/_vendor/pyproject_hooks/_in_process/_in_process.py", line 389, in <module>
          main()
        File "/home/aidroid/.conda/envs/vllm/lib/python3.11/site-packages/pip/_vendor/pyproject_hooks/_in_process/_in_process.py", line 373, in main
          json_out["return_val"] = hook(**hook_input["kwargs"])
                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        File "/home/aidroid/.conda/envs/vllm/lib/python3.11/site-packages/pip/_vendor/pyproject_hooks/_in_process/_in_process.py", line 209, in prepare_metadata_for_build_editable
          return hook(metadata_directory, config_settings)
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        File "/home/aidroid/.conda/envs/vllm/lib/python3.11/site-packages/setuptools/build_meta.py", line 463, in prepare_metadata_for_build_editable
          return self.prepare_metadata_for_build_wheel(
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        File "/home/aidroid/.conda/envs/vllm/lib/python3.11/site-packages/setuptools/build_meta.py", line 368, in prepare_metadata_for_build_wheel
          self.run_setup()
        File "/home/aidroid/.conda/envs/vllm/lib/python3.11/site-packages/setuptools/build_meta.py", line 313, in run_setup
          exec(code, locals())
        File "<string>", line 21, in <module>
      ModuleNotFoundError: No module named 'setuptools_scm'
      [end of output]
```

### dismatch licences - find setuptools version is old

(vllm) aidroid@aidroid-machine:~/projects/vllm$ pip list | grep setuptools 
setuptools               70.2.0
setuptools-scm           10.0.5

```
ValueError: invalid pyproject.toml config: `project`.
configuration error: `project` must not contain {'license-files'} properties
```
