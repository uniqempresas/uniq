import { AppShell } from "@/components/layout/app-shell";
import { Header } from "@/components/layout/header";
import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";
import { MessageCircle } from "lucide-react";

export default function ChatPage() {
  return (
    <AppShell header={<Header />}>
      <div className="flex flex-col items-center justify-center min-h-[calc(100vh-12rem)]">
        {/* Melissa Avatar */}
        <div className="relative mb-6">
          <Avatar size="lg" className="size-20 ring-4 ring-menta/20 shadow-lg shadow-menta/10">
            <AvatarImage
              src="/docs/design/MELISSA%20(2).png"
              alt="Melissa"
            />
            <AvatarFallback className="bg-menta/10 text-menta text-xl font-heading font-bold">
              M
            </AvatarFallback>
          </Avatar>
          <span className="absolute -bottom-1 -right-1 flex size-5 items-center justify-center rounded-full bg-menta ring-2 ring-white">
            <span className="sr-only">Online</span>
          </span>
        </div>

        {/* Title */}
        <h1 className="text-2xl font-heading font-bold text-grafite mb-2">
          Chat com a Melissa
        </h1>
        <p className="text-sm font-body text-cinza-verde text-center max-w-md mb-8">
          Sua parceira digital está pronta para ajudar. Pergunte sobre gestão,
          vendas, atendimento ou o que precisar para o seu negócio.
        </p>

        {/* Status indicator */}
        <div className="flex items-center gap-2 rounded-full bg-menta/10 px-4 py-2">
          <span className="flex size-2 rounded-full bg-menta animate-pulse" />
          <span className="text-xs font-body font-medium text-menta">
            Melissa está online
          </span>
        </div>

        {/* Placeholder message */}
        <div className="mt-12 flex flex-col items-center gap-3 text-cinza-verde/60">
          <MessageCircle className="size-8" />
          <p className="text-sm font-body">
            As mensagens aparecerão aqui em breve
          </p>
        </div>
      </div>
    </AppShell>
  );
}
