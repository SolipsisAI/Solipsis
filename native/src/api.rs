use cortex::core::{send_chat, Output};
use tokio;

#[frb(mirror(Output))]
pub struct _Output {
    pub text: String,
    pub conversation_id: String,
}

#[tokio::main]
pub async fn chat(text: String, conversation_id: String) -> Output {
    let response = send_chat(text, conversation_id).await;
    response
}
