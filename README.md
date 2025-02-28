# vllm_nvshmem

Build and publish NVSHMEM for [DeepEP](https://github.com/deepseek-ai/DeepEP)

```bash
pip install cmake
bash build.sh
python setup.py sdist bdist_wheel
twine upload dist/*
```