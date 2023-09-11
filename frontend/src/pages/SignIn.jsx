import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faGoogle } from '@fortawesome/free-brands-svg-icons';

function SignIn() {
    return (
        <section className="fullPage d-flex align-items-center" style={{ backgroundColor: "hsl(0, 0%, 96%)" }}>
            <div className="w-100 px-4 py-5 px-md-5 text-center text-lg-start">
                <div className="container">
                    <div className="row gx-lg-5 align-items-center">
                        <div className="col-lg-6 mb-5 mb-lg-0">
                            <h1 className="my-5 display-3 fw-bold ls-tight">
                                Allen High School <br />
                                <span className="text-primary">Conferences App</span>
                            </h1>
                            <p style={{ color: "hsl(217, 10%, 50.8%)" }}>
                                Lorem ipsum dolor sit amet consectetur adipisicing elit.
                                Eveniet, itaque accusantium odio, soluta, corrupti aliquam
                                quibusdam tempora at cupiditate quis eum maiores libero
                                veritatis? Dicta facilis sint aliquid ipsum atque?
                            </p>
                        </div>

                        <div className="col-lg-6 mb-5 mb-lg-0">
                            <div className="card">
                                <div className="card-body py-5 px-md-5">
                                    <form>
                                        {/* <div className="row">
                                            <div className="col-md-6 mb-4">
                                                <div className="form-outline">
                                                    <input type="text" id="form3Example1" className="form-control" />
                                                    <label className="form-label" htmlFor="form3Example1">First name</label>
                                                </div>
                                            </div>
                                            <div className="col-md-6 mb-4">
                                                <div className="form-outline">
                                                    <input type="text" id="form3Example2" className="form-control" />
                                                    <label className="form-label" htmlFor="form3Example2">Last name</label>
                                                </div>
                                            </div>
                                        </div> */}

                                        <div className="form-outline mb-4">
                                            <input type="email" id="signInEmail" className="form-control" />
                                            <label className="form-label" htmlFor="signInEmail">Email address</label>
                                        </div>

                                        <div className="form-outline mb-4">
                                            <input type="password" id="signInPassword" className="form-control" />
                                            <label className="form-label" htmlFor="signInPassword">Password</label>
                                        </div>

                                        <button type="submit" className="btn btn-primary btn-block mb-4">
                                            Sign In
                                        </button>

                                        <div className="text-center">
                                            <p>or sign in with:</p>
                                            <button type="button" className="btn btn-link btn-floating mx-1">
                                                <FontAwesomeIcon icon={faGoogle} />
                                            </button>
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

export default SignIn;