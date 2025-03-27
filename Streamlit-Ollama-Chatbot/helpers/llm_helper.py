"""
Demo
"""

import ollama
from config import Config

system_prompt = Config.SYSTEM_PROMPT

def chat(user_prompt, model):
    stream = ollama.chat(
      #  base_url="http://40.233.69.157:11434",  # specify your custom URL here
        model=model,
        messages=[{'role': 'assistant', 'content': system_prompt},
                  {'role': 'user', 'content': f"Model being used is {model}.{user_prompt}"}],
        stream=True,
    )

    return stream

# handles stream response back from LLM
def stream_parser(stream):
    for chunk in stream:
        yield chunk['message']['content']
