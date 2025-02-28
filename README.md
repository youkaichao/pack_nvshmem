# vllm_nvshmem

A script to build and use [DeepEP](https://github.com/deepseek-ai/DeepEP)

```bash
./prepare.sh host
# according to the output, set environment variables
git clone https://github.com/deepseek-ai/DeepEP
cd DeepEP
NVSHMEM_DIR=/path/to/vllm_nvshmem python setup.py -vvv install
```