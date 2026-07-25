import { z } from 'zod'

export const LoginSchema = z.object({
    email: z.email('Email invalido'),
    password:z.string().min(6,'A senha precisa ter no minimo 6 caracteres'),
});

export const RegisterSchema = z.object({
    name: z.string().trim().min(3, 'Nome muito curto').refine(val => val.includes(' '), 'Digite seu nome e sobrenome'),
    email:z.email('Email inválido'),
    phone: z.string().refine(val => {
        const numbers = val.replace(/\D/g, '');
        return numbers.length >= 10 && numbers.length <= 11;
    }, 'Telefone inválido (DDD + número)'),
    password:z.string().min(6,'Mínimo 6 caracteres'),
})

export type LoginInput =  z.infer<typeof LoginSchema>;
export type RegisterInput = z.infer<typeof RegisterSchema>;