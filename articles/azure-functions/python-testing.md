---
title: Unit Testing Python Azure Functions
description: Understand how to test your Python code projects to Azure Functions using the Python library for Azure Functions.
ms.topic: article
ms.date: 12/29/2024
ms.devlang: python
ms.custom:
  - devx-track-python
  - devdivchpfy22
  - ignite-2024
  - build-2025
---

# Unit Testing Python Azure Functions

## Unit testing through pytest

Functions that are written in Python can be tested like other Python code by using standard testing frameworks. For most bindings, it's possible to create a mock input object by creating an instance of an appropriate class from the `azure.functions` package. Since the [`azure.functions`](https://pypi.org/project/azure-functions/) package isn't immediately available, be sure to install it via your *requirements.txt* file.

With *my_second_function* as an example, the following example is a mock test of an HTTP-triggered function:

First, create the *<project_root>/function_app.py* file and implement the  `my_second_function` function as the HTTP trigger and `shared_code.my_second_helper_function`.

```python
# <project_root>/function_app.py
import azure.functions as func
import logging

# Use absolute import to resolve shared_code modules
from shared_code import my_second_helper_function

app = func.FunctionApp()

# Define the HTTP trigger that accepts the ?value=<int> query parameter
# Double the value and return the result in HttpResponse
@app.function_name(name="my_second_function")
@app.route(route="hello")
def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Executing my_second_function.')

    initial_value: int = int(req.params.get('value'))
    doubled_value: int = my_second_helper_function.double(initial_value)

    return func.HttpResponse(
        body=f"{initial_value} * 2 = {doubled_value}",
        status_code=200
    )
```

```python
# <project_root>/shared_code/__init__.py
# Empty __init__.py file marks shared_code folder as a Python package
```

```python
# <project_root>/shared_code/my_second_helper_function.py

def double(value: int) -> int:
  return value * 2
```

You can start writing test cases for your HTTP trigger.

```python
# <project_root>/tests/test_my_second_function.py
import unittest
import azure.functions as func

from function_app import main

class TestFunction(unittest.TestCase):
  def test_my_second_function(self):
    # Construct a mock HTTP request.
    req = func.HttpRequest(method='GET',
                           body=None,
                           url='/api/my_second_function',
                           params={'value': '21'})
    # Call the function.
    func_call = main.build().get_user_function()
    resp = func_call(req)
    # Check the output.
    self.assertEqual(
        resp.get_body(),
        b'21 * 2 = 42',
    )
```

Inside your Python virtual environment folder, install your favorite Python test framework, such as `pip install pytest`. Then run `pytest tests` to check the test result.

## Unit testing by invoking the function directly
With `azure-functions >= 1.21.0`, functions can also be called directly using the Python interpreter. This example shows how to unit test an HTTP trigger using the v2 programming model:
```python
# <project_root>/function_app.py
import azure.functions as func
import logging

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

@app.route(route="http_trigger")
def http_trigger(req: func.HttpRequest) -> func.HttpResponse:
    return "Hello, World!"

print(http_trigger(None))
```

With this approach, no extra package or setup is required. The function can be tested by calling `python function_app.py`, and it results in `Hello, World!` output in the terminal.

> [!NOTE]
> Durable Functions require special syntax for unit testing. For more information, see [Unit Testing Durable Functions in Python](durable/durable-functions-unit-testing-python.md)

## Testing through Docker
tbd