import { z } from 'zod'

export const LoginSchema = z.object({
    email: z.email('Email invalido'),
    password:z.string().min(6,'A senha precisa ter no minimo 6 caracteres'),
});

export const RegisterSchema = z.object({
    name:z.string().min(3,'nome muito curto'),
    email:z.email('Email inválido'),
    phone:z.string().regex(/^\d{10,11}$/,'Telefone inválido(DDD + número)'),
    password:z.string()
    .min(6,'Mínimo 6 caracteres'),
    dateOfBirth: z.coerce.date(),
})

export type LoginInput =  z.infer<typeof LoginSchema>;
export type RegisterInput = z.infer<typeof RegisterSchema>;