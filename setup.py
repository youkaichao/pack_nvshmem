from setuptools import setup, find_packages
setup(
    name="vllm_nvshmem",
    version="0.1",
    packages=find_packages("vllm_nvshmem"),
    package_data={'vllm_nvshmem': ['*.*']},
)