# Project Instructions

## Running VS Code on Google Colab using code-server

To run VS Code on Google Colab using code-server, follow these steps:

1. **Clone the repository**:
    ```bash
    !git clone https://github.com/yingtze/vscode-web-colab.git
    %cd yourrepository
    ```

2. **Make the scripts executable**:
    ```bash
    !chmod +x install.sh start-code-server.sh
    ```

3. **Run the installation script**:
    ```bash
    !bash install.sh
    ```

4. **Start code-server**:
    ```bash
    !bash start-code-server.sh
    ```

5. **Access VS Code**:
    Follow the instructions provided by code-server to access VS Code through your web browser.
