import { useEffect } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { Layout } from './components/Layout';
import { Home } from './pages/Home';
import { Expenses } from './pages/Expenses';
import { Details } from './pages/Details';
import { Suggestions } from './pages/Suggestions';
import { AddExpense } from './pages/AddExpense';
import { EditExpense } from './pages/EditExpense';
import { Login } from './pages/Login';
import { Signup } from './pages/Signup';
import { useStore } from './store/useStore';

function App() {
  const { fetchInitialData } = useStore();

  useEffect(() => {
    fetchInitialData();
  }, [fetchInitialData]);

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="/signup" element={<Signup />} />

        {/* Protected Routes */}
        <Route path="/*" element={
          localStorage.getItem('user') ? (
            <Layout>
              <Routes>
                <Route path="/" element={<Home />} />
                <Route path="/add" element={<AddExpense />} />
                <Route path="/expenses" element={<Expenses />} />
                <Route path="/expenses/:id" element={<Details />} />
                <Route path="/expenses/edit/:id" element={<EditExpense />} />
                <Route path="/suggestions" element={<Suggestions />} />
                <Route path="*" element={<Navigate to="/" replace />} />
              </Routes>
            </Layout>
          ) : (
            <Navigate to="/login" replace />
          )
        } />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
