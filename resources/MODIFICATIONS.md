# MODIFICATIONS  
A simple devlog for changes made to the core [`Auto-GPT`](https://github.com/Significant-Gravitas/Auto-GPT) to make it a bit less dumb in certain aspects.  
<sup><i>by <a target="_blank" href="https://gh.zod.tf">@zudsniper</a></i></sup>  

## `V0.3.0`
Released 5/4/2023, this is the most recent version of Auto-GPT. It "supposedly" supports plugins but YMMV as many on Discord & in the GH Issues had problems. Other changes are minimal.   

---  

### Modifications
1. Added handling for `git clone` (Handled)  
> [`[SOLUTION]`](https://github.com/Significant-Gravitas/Auto-GPT/issues/3507)  
> _by [@DanielNeedles](https://github.com/DanielNeedles)_   
  

### `PLANNED` Modifications
1. Handle **Halting Problem** when AGPT accidentally executes interative scripts.  
> [`[SOLUTION]`](https://github.com/Significant-Gravitas/Auto-GPT/issues/1327#issuecomment-1529410625)   
> _by [@Boostrix](https://github.com/Boostrix)_   

#### 🔄 `Discovery` 
> You can actually persoanlly interact with an interactive command such as `ssh-keygen` from an instance of an interactive shell which you maintain with the AutoGPT instance. I didn't know that.   

1a. `nano`, `vim`, _etc_  
    Handle these with the intent of writing data to a file if there is data which has already been generated.  

1b. `keygen` or other long command  
    How to handle these _not necessarily wrong_ but horribly inefficient choices? For instance, I'm watching my instance generate a 4096 instance right now 

2. `git push`  
     requires an email and a name via the git config commands, which must be configured prior to execution.  

2a.  `local` vs `remote` with respect to repos...  
   AutoGPT is pretty damn bad at figuring out what is happening in terms of synchronizing its work environment, and needs a fair bit of poking and prodding.  

3. **`Package Managers`!**  
    I think autobot should really be supplied whichever package manager it needs through the agent rather than trying to seek it out itself and deal with permissions it doesn't understand

4. No `source` command! 
    How to handle? 



---

### CRASHES  
These need to be wrapped with an exception handler like, yesterday.   

#### Prompt + StackTrack > LIMIT
Error causes > Token Limit Request, Causing Hard Crash  

```py
  Token limit: 4000
Traceback (most recent call last):
  File "/usr/local/lib/python3.10/runpy.py", line 196, in _run_module_as_main
    return _run_code(code, main_globals, None,
  File "/usr/local/lib/python3.10/runpy.py", line 86, in _run_code
    exec(code, run_globals)
  File "/app/autogpt/__main__.py", line 5, in <module>
    autogpt.cli.main()
  File "/usr/local/lib/python3.10/site-packages/click/core.py", line 1130, in __call__
    return self.main(*args, **kwargs)
  File "/usr/local/lib/python3.10/site-packages/click/core.py", line 1055, in main
    rv = self.invoke(ctx)
  File "/usr/local/lib/python3.10/site-packages/click/core.py", line 1635, in invoke
    rv = super().invoke(ctx)
  File "/usr/local/lib/python3.10/site-packages/click/core.py", line 1404, in invoke
    return ctx.invoke(self.callback, **ctx.params)
  File "/usr/local/lib/python3.10/site-packages/click/core.py", line 760, in invoke
    return __callback(*args, **kwargs)
  File "/usr/local/lib/python3.10/site-packages/click/decorators.py", line 26, in new_func
    return f(get_current_context(), *args, **kwargs)
  File "/app/autogpt/cli.py", line 151, in main
    agent.start_interaction_loop()
  File "/app/autogpt/agent/agent.py", line 75, in start_interaction_loop
    assistant_reply = chat_with_ai(
  File "/app/autogpt/chat.py", line 85, in chat_with_ai
    else permanent_memory.get_relevant(str(full_message_history[-9:]), 10)
  File "/app/autogpt/memory/redismem.py", line 133, in get_relevant
    query_embedding = create_embedding_with_ada(data)
  File "/app/autogpt/llm_utils.py", line 155, in create_embedding_with_ada
    return openai.Embedding.create(
  File "/usr/local/lib/python3.10/site-packages/openai/api_resources/embedding.py", line 33, in create
    response = super().create(*args, **kwargs)
  File "/usr/local/lib/python3.10/site-packages/openai/api_resources/abstract/engine_api_resource.py", line 153, in create
    response, _, api_key = requestor.request(
  File "/usr/local/lib/python3.10/site-packages/openai/api_requestor.py", line 226, in request
    resp, got_stream = self._interpret_response(result, stream)
  File "/usr/local/lib/python3.10/site-packages/openai/api_requestor.py", line 619, in _interpret_response
    self._interpret_response_line(
  File "/usr/local/lib/python3.10/site-packages/openai/api_requestor.py", line 682, in _interpret_response_line
    raise self.handle_error_response(
openai.error.APIError: The server had an error while processing your request. Sorry about that! You can retry your request, or contact us through our help center at help.openai.com if the error persists. (Please include the request ID 7d1fe816b1cd28dccf2e5b1c3b1a9658 in your message.) {
  "error": {
    "message": "The server had an error while processing your request. Sorry about that! You can retry your request, or contact us through our help center at help.openai.com if the error persists. (Please include the request ID XXXXXX in your message.)",
    "type": "server_error",
    "param": null,
    "code": null
  }
}
 500 {'error': {'message': 'The server had an error while processing your request. Sorry about that! You can retry your request, or contact us through our help center at help.openai.com if the error persists. (Please include the request ID XXXXXX in your message.)', 'type': 'server_error', 'param': None, 'code': None}} {'Date': 'Thu, 11 May 2023 06:55:31 GMT', 'Content-Type': 'application/json', 'Content-Length': '366', 'Connection': 'keep-alive', 'access-control-allow-origin': '*', 'openai-organization': 'zod-tf', 'openai-processing-ms': '30026', 'openai-version': '2020-10-01', 'strict-transport-security': 'max-age=15724800; includeSubDomains', 'x-ratelimit-limit-requests': '3000', 'x-ratelimit-remaining-requests': '2999', 'x-ratelimit-reset-requests': '20ms', 'x-request-id': XXXXXX', 'CF-Cache-Status': 'DYNAMIC', 'Server': 'cloudflare', 'CF-RAY': 'XXXXX', 'alt-svc': 'h3=":443"; ma=86400, h3-29=":443"; ma=86400'}
Error: ${DOCKER_COMPOSE_ALIAS} run --rm ${AGPT_CONTAINER_NAME} ${EXTRA_DOCKER_COMPOSE_COMMANDS} exited with status 1
```

`agpt-toolkit`
