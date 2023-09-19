
import React, { useEffect, useState, useCallback } from 'react';
import { Table, Button, Container, Modal } from 'react-bootstrap';

import AdminNavbar from '../components/AdminNavbar'

function Admin() {
    const [origData, setOrigData] = useState(null);
    const [teachersData, setTeachersData] = useState(null);
    const [didChange, setDidChange] = useState(false);

    const handleOnChange = (event) => {
        const { name, value } = event.target;
        const index = event.target.parentElement.parentElement.dataset.index;
        const copy = [...teachersData]
        copy[index][name] = value;
        setTeachersData(copy);
        setDidChange(true);
    };

    const handlePressEnter = (event) => {
        if (event.keyCode === 13 || event.key === 'Enter') {
            event.target.blur();
            return false;
        }
    };

    const [showConfirm, setShowConfirm] = useState(false);
    const [confirmEvent, setConfirmEvent] = useState(false);
    const [changeProp, setChangeProp] = useState("");
    const [changePropFrom, setChangePropFrom] = useState("");
    const [changePropTo, setChangePropTo] = useState("");

    const handleClose = () => setShowConfirm(false);
    const handleShow = () => setShowConfirm(true);

    const capitalizeFirst = (str) => {
	return str.charAt(0).toUpperCase() + str.slice(1);
    }

    const handleBlurEditable = (e) => {
        if (didChange) {
	    setConfirmEvent(e);

	    const { name } = e.target;
            const index = e.target.parentElement.parentElement.dataset.index;

	    setChangeProp(capitalizeFirst(name));
	    setChangePropFrom(origData[index][name].toString());
	    setChangePropTo(teachersData[index][name].toString());

	    handleShow();
	}
    };

    const handleCancel = () => {
	const { name } = confirmEvent.target;
        const index = confirmEvent.target.parentElement.parentElement.dataset.index;
        const copy = [...teachersData]
        copy[index][name] = origData[index][name];
        setTeachersData(copy);

	handleClose();
    }

    const sendUpdateRequest = () => {
	const e = confirmEvent;
	console.log('changed');
	
	const obj = {}
	obj[e.target.name] = e.target.value;
	
	fetch("./adminPanel/updateUser/" + teachersData[e.target.parentElement.parentElement.dataset.index].id, {
	    headers: {
		Accept: "application/json",
		"Content-Type": "application/json",
	    },
	    method: "PATCH",
	    body: JSON.stringify(obj)
	});

	const { name } = confirmEvent.target;
        const index = confirmEvent.target.parentElement.parentElement.dataset.index;
        const copy = [...origData]
        copy[index][name] = teachersData[index][name];
        setOrigData(copy);

	handleClose();
    }
    
    const editableCell = (type, cellInfo) => {
        return (
            <td>
                <input 
                    name={type}
                    type='text'
                    value={cellInfo}
                    style={{ width: '100%', borderSizing: 'border-box', border: 'none', padding: '0.5rem' }}
                    data-starting={ cellInfo }
                    onChange={handleOnChange}
                    onBlur={handleBlurEditable}
                    onFocus={(e) => { setDidChange(false); }}
                    onKeyDown={handlePressEnter}
                />
            </td>
        );
    }
    
    function loadTeachers() {
        setTeachersData(null);
        fetch("./adminPanel/data")
            .then((response) => response.json())
            .then((json) => {
		setTeachersData(json);
		const copy = JSON.parse(JSON.stringify(json));
		setOrigData(copy);
	    });
    }

    useEffect(() => {
        loadTeachers();
    }, []);

    return (
        <main className="fullPage" style={{ backgroundColor: "hsl(0, 0%, 96%)" }}>
            <AdminNavbar />
            <section className="d-flex align-items-center">
                <div className="w-100 px-4 py-5 px-md-5 text-center text-lg-start">
                    <Container>
                        <Table responsive>
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>First Name</th>
                                    <th>Last Name</th>
                                    <th>Email Address</th>
                                    <th className='text-center'>Availability</th>
                                </tr>
                            </thead>
                            <tbody>
                                { teachersData &&
                                  teachersData.map((data, i) => {
                                        return (
                                            <tr className='align-middle' data-index={i}>
                                                <td>{data.id}</td>
                                                { editableCell('firstName', data.firstName) }
                                                { editableCell('lastName', data.lastName) }
                                                { editableCell('email', data.email) }

                                                <td className='text-center'>
                                                    <Button className="text-nowrap">Show Availability</Button>
                                                </td>
                                            </tr>
                                        );
                                    })
                                }
                            </tbody>
                        </Table>
                    </Container>
                </div>
            </section>

	    <Modal
		show={showConfirm}
		onHide={handleCancel}
		size="lg"
		aria-labelledby="contained-modal-title-vcenter"
		centered
	    >
		<Modal.Header closeButton>
		    <Modal.Title id="contained-modal-title-vcenter" className="text-center">
			Confirm User Update
		    </Modal.Title>
		</Modal.Header>
		<Modal.Body className="text-center">
		    <h4>{changeProp.replace("Name", " Name")}</h4>
		    <p>
			{changePropFrom} -> {changePropTo}
		    </p>
		</Modal.Body>
		<Modal.Footer>
		    <Button variant="danger" onClick={handleCancel}>
			Cancel
		    </Button>
		    <Button variant="primary" onClick={sendUpdateRequest}>
			Confirm
		    </Button>
		</Modal.Footer>
	    </Modal>
        </main>
    );
}

export default Admin;
