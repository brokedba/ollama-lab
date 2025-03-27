"""
Demo
"""

import ollama
from config import Config
# sets up the system prompt
system_prompt = Config.SYSTEM_PROMPT

def chat(user_prompt, model):
    # Instantiate the client with the custom URL
    client = ollama.Client(host=Config.BASE_URL)
    # Use the client to initiate the chat with the model
    stream = client.chat(
        model=model,
        messages=[{'role': 'assistant', 'content': system_prompt},
                  {'role': 'user', 'content': f"Model being used is {model}.{user_prompt}"}],
        stream=True,
    )
   # print(stream)
    return stream

# handles stream response back from LLM
def stream_parser(stream):
    for chunk in stream:
        yield chunk['message']['content']
