const userCreateForm = document.getElementById("createUserForm");
const userCreateButton = document.getElementById("userCreateButton");
const editModeButton = document.getElementById("editMode");
var editMode = false;

editModeButton.addEventListener("click", (e) => {
    e.preventDefault();

    currentvalue = editModeButton.innerHTML;
    if(currentvalue == "Edit Mode: Off"){
	editModeButton.innerHTML = "Edit Mode: On";
	editMode = true;
	toggleEditMode(editMode);
    }else{
	editModeButton.innerHTML = "Edit Mode: Off";
	editMode = false;
	toggleEditMode(editMode);
    }
})

function toggleEditMode(isOn) {
    const table = document.getElementById("userTable");
    const tr = table.getElementsByTagName("tr");
    
    if(isOn) {
	for (i = 1; i < tr.length; i++) {
	    var name = tr[i].getElementsByTagName("td")[1];
	    name.setAttribute("contenteditable", "true");
	    var userID = tr[i].getElementsByTagName("td")[2];
	    userID.setAttribute("contenteditable", "true");

	    var canView = tr[i].getElementsByTagName("td")[3];
	    	    
	    var canEdit = tr[i].getElementsByTagName("td")[4];
		    
	    var isAdmin = tr[i].getElementsByTagName("td")[5];    
	}

	var checkboxes = document.getElementsByClassName("Chk");
	var removeButtons = document.getElementsByClassName("removeButton");
	for (i = 0; i<checkboxes.length; i++)
	{
	    checkboxes[i].disabled = false;
	    
	}
	for (i = 0; i<removeButtons.length; i++)
	{
	   removeButtons[i].disabled = false;
	    
	}
    }
    else {
	for (i = 1; i < tr.length; i++) {
	    var name = tr[i].getElementsByTagName("td")[1];
	    name.setAttribute("contenteditable", "false");
	    var userID = tr[i].getElementsByTagName("td")[2];
	    userID.setAttribute("contenteditable", "false");

	    var canView = tr[i].getElementsByTagName("td")[3];

	    var canEdit = tr[i].getElementsByTagName("td")[4];
	    	    
	    var isAdmin = tr[i].getElementsByTagName("td")[5];
	}

	var checkboxes = document.getElementsByClassName("Chk");
	var removeButtons = document.getElementsByClassName("removeButton");
	for (i = 0; i<checkboxes.length; i++)
	{
	    checkboxes[i].disabled = true;
	    
	}
	for (i = 0; i<removeButtons.length; i++)
	{
	   removeButtons[i].disabled = true;
	    
	}
	
	//todo: save
    }
    
}

function onRemoveButtonClick(el) {
    if(!confirm("Are you sure you want to delete?")) return;
    
    var tbl = el.parentNode.parentNode.parentNode;
    var rowIndex = el.parentNode.parentNode.rowIndex;
    var row = tbl.rows[rowIndex];
    var userId = row.cells[2].innerHTML;
       
    if (sendUserRemove(userId)) {	
	setTimeout(() => {  refreshUserTable(); }, 500);
    }

}

function createUserTable(users) {
    for (let i = 0; i < users.length; i++) {
	const user = users[i];
	
	// Find a <table> element with id="userTable":
	var table = document.getElementById("userTable");
	
	// Create an empty <tr> element and add it to the 1st position of the table:
	var row = table.insertRow(i+1);
	
	// Insert new cells (<td> elements) at the 1st and 2nd position of the "new" <tr> element:
	var id = row.insertCell(0);
	var name = row.insertCell(1);
	name.setAttribute("contenteditable", "false");
	var userID = row.insertCell(2);
	userID.setAttribute("contenteditable", "false");
	var canView = row.insertCell(3);
	var canEdit = row.insertCell(4);
	var isAdmin = row.insertCell(5);
	
	// Add some text to the new cells:
	var removeButton = document.createElement('button');
	removeButton.setAttribute('onClick', 'onRemoveButtonClick(this)');
	removeButton.disabled = !editMode;
	removeButton.classList.add('removeButton');
	removeButton.innerHTML = "removeButton";
	
	id.innerHTML = user.id;
	id.appendChild(removeButton);
	name.innerHTML = user.name;
	userID.innerHTML = user.userID;
	
	var canViewChk = document.createElement('input');
	canViewChk.setAttribute('type', 'checkbox');
	canViewChk.classList.add('Chk');
	canViewChk.checked = user.canView;
	canViewChk.disabled = !editMode;
	canView.appendChild(canViewChk);
	
	var canEditChk = document.createElement('input');
	canEditChk.setAttribute('type', 'checkbox');
	canEditChk.classList.add('Chk');
	canEditChk.checked = user.canEdit;
	canEditChk.disabled = !editMode;
	canEdit.appendChild(canEditChk);

	var isAdminChk = document.createElement('input');
	isAdminChk.setAttribute('type', 'checkbox');
	isAdminChk.classList.add('Chk');
	isAdminChk.checked = user.isAdmin;
	isAdminChk.disabled = !editMode;
	isAdmin.appendChild(isAdminChk);

    }
}

async function refreshUserTable() {
    const table = document.getElementById("userTable");
    const tr = table.getElementsByTagName("tr");

    // delete all elements
    const rowCount = table.rows.length;
    for (i = 1; i<rowCount; i++) {
	table.deleteRow(1);
    }
    
    var users = await getUsersFromServer();
    createUserTable(users);

}

userCreateButton.addEventListener("click", (e) => {
    e.preventDefault();
    const name = userCreateForm.name.value;
    const userID = userCreateForm.userID.value;
    const canView = userCreateForm.canView.checked;
    const canEdit = userCreateForm.canEdit.checked;
    const isAdmin = userCreateForm.isAdmin.checked;

    if (sendUserCreate(name, userID, canView, canEdit, isAdmin)) {	
	refreshUserTable();
    }
})

async function getUsersFromServer() {
    return new Promise((resolve, reject) => {
	const xhr = new XMLHttpRequest();
	xhr.open("GET", "./adminPanel/data");
	xhr.send();
	xhr.responseType = "json";
	xhr.onload = () => {
	    if (xhr.readyState == 4 && xhr.status == 200) {
		const data = xhr.response;
		//console.log(data;)
		resolve(data);
	    } else {
		console.log(`Error: ${xhr.status}`);
		reject(xhr.status);
	    }
	};
    });
}

async function sendUserCreate(name, userID, canView, canEdit, isAdmin) {
    const response = await fetch("./adminPanel/createUser", {
	method: 'POST',
	headers: {
	    'Accept': 'application/json',
	    'Content-Type': 'application/json'
	},
	body: `{"name": "${name}", "userID": "${userID}", "canView": ${canView}, "canEdit": ${canEdit}, "isAdmin": ${isAdmin} }`,
    });

    response.json().then(data => {
	if (data.reason){
	    alert(data.reason);
	    return false;
	}
	else if (data.error){
	    alert(data.error)
	    return true;
	}
    });
}

async function sendUserRemove(userID) {
    const response = await fetch("./adminPanel/removeUser", {
	method: 'POST',
	headers: {
	    'Accept': 'application/json',
	    'Content-Type': 'application/json'
	},
	body: `{"userID": "${userID}"}`,
    });

    response.json().then(data => {
	if (data.reason){
	    console.error(data.reason);
	    return false;
	}
	else if (data.error){
	    console.log(data.error)
	    return true;
	}
    });
}

document.addEventListener("DOMContentLoaded", async function () {
    var users = await getUsersFromServer();
    
    // if got the users from the server without error
    createUserTable(users);
    
});

function userSearch() {
    // Declare variables
    var input, filter, table, tr, td, i, txtValue;
    input = document.getElementById("userSearch");
    filter = input.value.toUpperCase();
    table = document.getElementById("userTable");
    tr = table.getElementsByTagName("tr");
    
    // Loop through all table rows, and hide those who don't match the search query
    for (i = 0; i < tr.length; i++) {
	td = tr[i].getElementsByTagName("td")[1];
	if (td) {
	    txtValue = td.textContent || td.innerText;
	    if (txtValue.toUpperCase().indexOf(filter) > -1) {
		tr[i].style.display = "";
	    } else {
		tr[i].style.display = "none";
	    }
	}
    }
}

// Get the modal
var modal = document.getElementById("userCreateModal");

// Get the button that opens the modal
var btn = document.getElementById("addUser");

// Get the <span> element that closes the modal
var span = document.getElementsByClassName("close")[0];

// When the user clicks on the button, open the modal
btn.onclick = function() {
    modal.style.display = "block";
}

// When the user clicks on <span> (x), close the modal
span.onclick = function() {
    modal.style.display = "none";
}

// When the user clicks anywhere outside of the modal, close it
window.onclick = function(event) {
    if (event.target == modal) {
	modal.style.display = "none";
    }
}
