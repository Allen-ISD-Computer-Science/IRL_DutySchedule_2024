
const notificationButton = document.getElementById("notification-button");

//doing something on click
function testEmail() {

    notificationButton.addEventListener("click", async () => {
	const email = prompt("Enter your email address:");

	if (email) {
	    try {
		const response = await fetch("/send-notification", {
		    method: 'POST',
		    headers: {
			'Content-Type': 'application/json'
		    },
		    body: JSON.stringify({ email })
		});

		if (response.ok) {
		    alert("Notification sent successfully!");
		} else {
		    alert("Failed to send notification.");
		}
	    } catch (error) {
		alert("An error occurred while sending the notification.");
		console.error(error);
	    }
	}
    });
}
