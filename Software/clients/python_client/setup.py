from setuptools import setup

setup(name='all_spark_cube_client',
      version='0.1',
      description='Python client library for the All Spark Cube',
      classifiers=[
        'Development Status :: 3 - Alpha',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python :: 2.7',
        'Topic :: System :: Distributed Computing',
      ],
      url='https://github.com/chadharrington/all_spark_cube',
      author='Chad Harrington',
      author_email='chad.harrington@gmail.com',
      license='MIT',
      packages=['all_spark_cube_client'],
      py_modules=['all_spark_cube_client'],
      install_requires=['thrift'],
      zip_safe=False)
