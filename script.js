function startListening() {
  const recognition = new (window.SpeechRecognition || window.webkitSpeechRecognition)();
  recognition.lang = 'en-US';

  recognition.start();

  recognition.onresult = function(event) {
    const text = event.results[0][0].transcript.toLowerCase();
    document.getElementById("userText").innerText = text;

    let response = "";

    if (text.includes("fever") || text.includes("temperature")) {
      response = "You may have a common fever. Take rest, drink fluids, and consult a doctor if it lasts more than two days.";
    } 
    else if (text.includes("headache") || text.includes("head pain")) {
      response = "Headache may be due to stress or dehydration. Rest well and consult a doctor if it is severe or frequent.";
    } 
    else if (text.includes("chest pain") || text.includes("breathing")) {
      response = "This could be a medical emergency. Please visit the nearest hospital immediately.";
    } 
    else {
      response = "Sorry, I could not understand the symptoms. Please consult a doctor.";
    }

    document.getElementById("botResponse").innerText = response;
    speak(response);
  };
}

function speak(message) {
  const speech = new SpeechSynthesisUtterance(message);
  speech.lang = 'en-US';
  window.speechSynthesis.speak(speech);
}
