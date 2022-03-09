use cortex::ops::dialoguer::DialogueManager;
use cortex::ops::question_answerer::QuestionAnswerManager;
use cortex::ops::summarizer::SummaryManager;

pub fn ask_me(model_dir_path: String, question: String, context: String) -> String {
    let manager = QuestionAnswerManager::new(model_dir_path);
    manager.ask(question, context)
}

pub fn chat(model_dir_path: String, text: String) -> String {
    let mut manager = DialogueManager::new(model_dir_path);
    manager.send(text)
}

pub fn summarize(model_dir_path: String, text: String) -> String {
    let manager = SummaryManager::new(model_dir_path);
    manager.summarize(text)
}
