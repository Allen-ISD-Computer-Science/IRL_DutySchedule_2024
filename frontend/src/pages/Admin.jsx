import React, { useEffect, useState, useCallback } from 'react';
import Table from 'react-bootstrap/Table';

import Navbar from '../components/Navbar'

function Admin() {
    const [teachersData, setTeachersData] = useState(null);
    const [didChange, setDidChange] = useState(false);

    const handleOnChange = useCallback(event => {
        const { name, value } = event.target;
        const index = event.target.parentElement.parentElement.dataset.index;
        const copy = [...teachersData]
        copy[index][name] = value;
        setTeachersData(copy);
        setDidChange(true);
    });

    const handlePressEnter = useCallback(event => {
        if (event.keyCode === 13 || event.key === 'Enter') {
            event.target.blur();
            return false;
        }
    });
    
    function editableCell(type, cellInfo) {
        return (
            <td>
                <input 
                    name={type}
                    type='text'
                    value={cellInfo}
                    style={{ width: '100%', borderSizing: 'border-box', border: 'none', padding: '0.5rem' }}
                    data-starting={ cellInfo }
                    onChange={handleOnChange}
                    onBlur={(e) => {
                        if (didChange) {
                            console.log('changed');

                            // todo: send api request to update data
                            // avaliable: teachersData[e.target.parentElement.parentElement.dataset.index].id,
                            //            key: event.target.name, value: event.target.value
                        }
                    }}
                    onFocus={(e) => { setDidChange(false); }}
                    onKeyDown={handlePressEnter}
                />
            </td>
        );
    }

    function loadTeachers() {
        setTeachersData(null);
        // fetch("http://localhost:8080/api/teachers/")
        //   .then((response) => response.json())
        //   .then((json) => setTeachersData(json));
        const array = [];
        const firstNames = ["John", "Jane", "Jack", "Jill", "James", "Judy", "Jenny", "Jesse", "Jasmine", "Jasper", "Jade", "Jared", "Jocelyn", "Jude", "Jenna", "Javier"];
        const lastNames = ["Doe", "Smith", "Johnson", "Williams", "Jones", "Brown", "Davis", "Miller", "Wilson", "Moore", "Taylor", "Anderson", "Thomas", "Jackson", "White", "Harris"];
        for (let i = 0; i < 100; i++) {
            // generate random data
            const firstName = firstNames[Math.floor(Math.random() * firstNames.length)];
            const lastName = lastNames[Math.floor(Math.random() * lastNames.length)];
            array.push({
                id: i + 1,
                firstName: firstName,
                lastName: lastName,
                email: `${firstName.toLowerCase()}.${lastName.toLowerCase()}@allenisd.org`,
            });
        }
        setTeachersData(array);
    }

    useEffect(() => {
        loadTeachers();
    }, []);

    return (
        <main className="fullPage" style={{ backgroundColor: "hsl(0, 0%, 96%)" }}>
            <Navbar />
            <section className="d-flex align-items-center">
                <div className="w-100 px-4 py-5 px-md-5 text-center text-lg-start">
                    <div className="container">
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
                                    teachersData.map(data => {
                                        return (
                                            <tr className='align-middle' data-index={data.id - 1}>
                                                <td>{data.id}</td>
                                                { editableCell('firstName', data.firstName) }
                                                { editableCell('lastName', data.lastName) }
                                                { editableCell('email', data.email) }

                                                <td className='text-center'>
                                                    <button className="btn btn-primary text-nowrap">Show Avaliability</button>
                                                </td>
                                            </tr>
                                        );
                                    })
                                }
                            </tbody>
                        </Table>
                    </div>
                </div>
            </section>
        </main>
    );
}

export default Admin;