import { useState, useEffect, useRef } from "react";

import Button from "react-bootstrap/Button";

function UpdateAccount() {
    const [password, setPassword] = useState("");
    const [confirmPassword, setConfirmPassword] = useState("");

    async function sendAccountVerify(e) {
        e.preventDefault();

        const segments = new URL(window.location.href).pathname.split('/');
        const last = segments.pop() || segments.pop();
        const token = last;

        //const url = (new URL(window.location.href).pathname).includes("updateAccount") ? "../forgotPassword" : "../verify";
        
        const response = await fetch(segments.join('/'), {
        method: 'POST',
        headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
        },
        body: `{"password": "${password}", "confirmPassword": "${confirmPassword}", "token": "${token}"}`,
        });
    
        response.json().then(data => {
        //const alertString = JSON.parse(data);
    //	console.log(data)
        if (data.reason){
            alert(data.reason);
        }
        else if (data.error){
            if (data.error === "Account successfully created."){
                window.location.href = "../signin";
            }
            else if (data.error === "Account already verified."){
                window.location.href = "../signin";
            }
            else {
                alert(data.error)
            }
        }
        });
    }

    const initialized = useRef(false)

    useEffect(() => {
        if (!initialized.current) {
            initialized.current = true

            // if no token, alert and redirect to signin
            const segments = new URL(window.location.href).pathname.split('/');
            const last = segments.pop() || segments.pop();
            const token = last;

            if (!token || token === 'verify') {
                alert("No verify token provided.");
                window.location.href = "../signin";
            }
        }
    });

    return (
        <section
            className="fullPage d-flex align-items-center"
            style={{ backgroundColor: "hsl(0, 0%, 96%)" }}
        >
            <div className="w-100 px-4 py-5 px-md-5 text-center text-lg-start">
                <div className="container">
                    <div className="row gx-lg-5 align-items-center">
                        <div className="col-lg-6 mb-5 mb-lg-0">
                            <h1 className="my-5 display-3 fw-bold ls-tight">
                                Allen High School <br />
                                <span className="text-primary">
				    Duty Dashboard
                                </span>
                            </h1>
                            <p style={{ color: "hsl(217, 10%, 50.8%)" }}>
                                The go-to app for educators who want to
                                streamline their daily routines, reduce stress,
                                and maximize productivity. Say goodbye to the
                                chaos of managing your duties and hello to a
                                more organized and efficient teaching
                                experience! Start using today to simplify your
                                teaching life.
                            </p>
                        </div>

                        <div className="col-lg-6 mb-5 mb-lg-0">
                            <div className="card">
                                <div className="card-body py-5 px-md-5">
                                    <form onSubmit={sendAccountVerify}>
                                        <div className="form-outline mb-4">
                                            <input
                                                type="password"
                                                id="verifyPassword"
                                                className="form-control"
                                                value={password}
                                                onChange={(e) =>
                                                    setPassword(
                                                        e.currentTarget.value
                                                    )
                                                }
                                                required
                                            />
                                            <label
                                                className="form-label"
                                                htmlFor="verifyPassword"
                                            >
                                                Password
                                            </label>
                                        </div>

                                        <div className="form-outline mb-4">
                                            <input
                                                type="password"
                                                id="verifyConfPassword"
                                                className="form-control"
                                                value={confirmPassword}
                                                onChange={(e) =>
                                                    setConfirmPassword(
                                                        e.currentTarget.value
                                                    )
                                                }
                                                required
                                            />
                                            <label
                                                className="form-label"
                                                htmlFor="verifyConfPassword"
                                            >
                                                Confirm Password
                                            </label>
                                        </div>

                                        <Button
                                            varient="primary"
                                            className="btn-block mb-4"
                                            type="submit"
                                        >
                                            Update Password
                                        </Button>

                                        <div className="text-center">
                                            <p>Already have an account?</p>
                                            <a href="./signin">Sign In</a>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    );
}

export default UpdateAccount;
