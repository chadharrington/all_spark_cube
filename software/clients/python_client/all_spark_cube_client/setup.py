import ez_setup
ez_setup.use_setuptools()

from setuptools import setup, find_packages

setup(name='all_spark_cube_client',
      version='0.5',
      description='Python client library for the All Spark Cube',
      classifiers=[
          'Development Status :: 4 - Beta',
          'License :: OSI Approved :: MIT License',
          'Programming Language :: Python :: 2.7',
          'Intended Audience :: Developers',
          'Topic :: System :: Distributed Computing'],
      url='https://github.com/chadharrington/all_spark_cube',
      author='Chad Harrington',
      author_email='chad.harrington@gmail.com',
      license='MIT',
      packages=find_packages(),
      install_requires=['thrift'])

