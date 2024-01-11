import React from 'react';
import ReactDOM from 'react-dom/client';
import { createBrowserRouter, RouterProvider } from 'react-router-dom';

import './index.css';
import 'bootstrap/dist/css/bootstrap.min.css';

import ErrorPage from "./pages/ErrorPage";
import SignIn from './pages/SignIn';
import SignUp from './pages/SignUp';
import UpdateAccount from './pages/UpdateAccount';
import Forgot from './pages/Forgot';

import Dashboard from './pages/authRequired/Dashboard';
import Calendar from './pages/authRequired/CalendarPage';

import Admin from './pages/adminRequired/Admin';
import Upload from './pages/adminRequired/Upload';

const router = createBrowserRouter([
  {
    path: "/",
    errorElement: <ErrorPage />,
  },
  {
    path: "/signin",
    element: <SignIn />,
  },
  {
    path: "/forgot",
    element: <Forgot />,
  },
  {
    path: "/signup",
    element: <SignUp />,
  },
  {
    path: "/verify",
    element: <UpdateAccount />,
  },
  {
    path: "/verify/*",
    element: <UpdateAccount />,
  },
  {
    path: "/forgotPassword",
    element: <UpdateAccount />,
  },
  {
    path: "/forgotPassword/*",
    element: <UpdateAccount />,
  },
  {
    path: "/dashboard",
    element: <Dashboard />,
  },
  {
    path: "/calendar",
    element: <Calendar />,
  },
  {
    path: "/adminPanel",
    element: <Admin />,
  },
  {
    path: "/adminPanel/upload",
    element: <Upload />,
  },
],
{
  basename: process.env.PUBLIC_URL ? `${process.env.PUBLIC_URL}/` : "/",
});

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <RouterProvider router={router} />
  </React.StrictMode>
);
