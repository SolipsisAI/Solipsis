use cortex::core::send_chat;
use tokio;

#[tokio::main]
pub async fn chat(text: String) -> String {
    let response = send_chat(text).await;
    response
}
