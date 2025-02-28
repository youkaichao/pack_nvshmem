from setuptools import setup
setup(
    name="vllm_nvshmem",
    version="0.1",
    packages=["vllm_nvshmem"],
    package_data={'vllm_nvshmem': ['*.*']},
)