"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

export async function signIn(email: string, password: string) {
  const supabase = await createClient();

  const { error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error) {
    let message = "Erro ao fazer login. Tente novamente.";

    if (error.message.includes("Invalid login credentials")) {
      message = "Email ou senha incorretos.";
    } else if (error.message.includes("Email not confirmed")) {
      message = "Seu email ainda não foi confirmado. Verifique sua caixa de entrada.";
    } else if (error.message.includes("rate_limit")) {
      message = "Muitas tentativas. Aguarde alguns minutos e tente novamente.";
    }

    return { error: message };
  }

  revalidatePath("/", "layout");
  return { success: true };
}

export async function signOut() {
  const supabase = await createClient();
  const { error } = await supabase.auth.signOut();

  if (error) {
    return { error: "Erro ao sair. Tente novamente." };
  }

  revalidatePath("/", "layout");
  return { success: true };
}
