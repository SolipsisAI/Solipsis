use cortex::core::send_chat;
use tokio;

#[tokio::main]
pub async fn chat(text: String, user_id: String) -> String {
    let response = send_chat(text, user_id).await;
    response
}
