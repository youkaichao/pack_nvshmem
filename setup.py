from setuptools import setup, find_packages

setup(
    name="vllm_nvshmem",
    version="0.1",
    packages=["vllm_nvshmem", "vllm_nvshmem.lib", "vllm_nvshmem.include", "vllm_nvshmem.share"],
    include_package_data=True,
)