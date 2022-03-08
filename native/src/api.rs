extern crate cortex;

pub fn ask(question: String, context: String) -> String {
    cortex::api::ask(question, context)
}
