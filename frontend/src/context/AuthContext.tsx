import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { getStorageItemAsync, setStorageItemAsync, deleteStorageItemAsync } from '../utils/storage';
import { login as loginService } from '../services/authServices';

type User = {
  id: string;
  name: string;
  email: string;
};

type AuthContextType = {
  user: User | null;
  isLoading: boolean;
  signIn: (email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
};

const AuthContext = createContext<AuthContextType | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    async function loadStorageData() {
      const token = await getStorageItemAsync('authToken');
      const userStr = await getStorageItemAsync('authUser');
      
      if (token && userStr) {
        setUser(JSON.parse(userStr));
      }
      setIsLoading(false);
    }
    loadStorageData();
  }, []);

  async function signIn(email: string, password: string) {
    const { token, user } = await loginService(email, password);
    await setStorageItemAsync('authToken', token);
    await setStorageItemAsync('authUser', JSON.stringify(user));
    setUser(user);
  }

  async function signOut() {
    await deleteStorageItemAsync('authToken');
    await deleteStorageItemAsync('authUser');
    setUser(null);
  }

  return (
    <AuthContext.Provider value={{ user, isLoading, signIn, signOut }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth precisa ser usado dentro de um AuthProvider');
  }
  return context;
}