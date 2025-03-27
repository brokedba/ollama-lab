"""
Demo
"""

class Config:
    PAGE_TITLE = "Funky Ollama3 Chatbot"
    BASE_URL = "http://1270.0.0.1"   # Use Your remote ollama base URL if not local or the port != 11443  
    OLLAMA_MODELS = ('llama3', 'codellama:13b') # CHANGE ME - it has to match available model in your ollama backend
    # , 'llama2-uncensored' ,'llama2:7b', 'llama2:13b', 'mistral', 'mixtral')

    SYSTEM_PROMPT = f"""You are a helpful chatbot that has access to the following 
                    open-source models {OLLAMA_MODELS}.
                    You can can answer questions for users on any topic."""
    
