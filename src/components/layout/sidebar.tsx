"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/utils";
import {
  LayoutDashboard,
  MessageCircle,
  Users,
  Puzzle,
  Wallet,
  Package,
  Calendar,
  BarChart3,
  ChevronRight,
} from "lucide-react";
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet";
import { Separator } from "@/components/ui/separator";
import { Menu } from "lucide-react";

type NavItem = {
  label: string;
  href: string;
  icon: React.ElementType;
  disabled?: boolean;
  badge?: string;
};

const mainNavItems: NavItem[] = [
  { label: "Dashboard", href: "/dashboard", icon: LayoutDashboard },
  { label: "Chat (Melissa)", href: "/chat", icon: MessageCircle },
  { label: "CRM", href: "/crm", icon: Users },
  { label: "Módulos", href: "/modulos", icon: Puzzle },
];

const futureNavItems: NavItem[] = [
  { label: "Financeiro", href: "#", icon: Wallet, disabled: true, badge: "Em breve" },
  { label: "Estoque", href: "#", icon: Package, disabled: true, badge: "Em breve" },
  { label: "Agenda", href: "#", icon: Calendar, disabled: true, badge: "Em breve" },
  { label: "Relatórios", href: "#", icon: BarChart3, disabled: true, badge: "Em breve" },
];

function SidebarNav() {
  const pathname = usePathname();

  return (
    <nav className="flex flex-1 flex-col gap-1 px-3">
      {/* Main navigation */}
      <div className="space-y-1">
        <p className="px-3 text-[11px] font-heading font-semibold uppercase tracking-[0.08em] text-white/40">
          Principal
        </p>
        {mainNavItems.map((item) => {
          const Icon = item.icon;
          const isActive = pathname === item.href || pathname.startsWith(item.href + "/");

          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "group flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-all duration-150",
                isActive
                  ? "bg-menta/15 text-menta"
                  : "text-white/70 hover:bg-white/[0.06] hover:text-white/90"
              )}
            >
              <Icon className="size-5 shrink-0" />
              <span>{item.label}</span>
              {isActive && (
                <ChevronRight className="ml-auto size-4 text-menta" />
              )}
            </Link>
          );
        })}
      </div>

      <Separator className="my-3 bg-white/10" />

      {/* Future modules */}
      <div className="space-y-1">
        <p className="px-3 text-[11px] font-heading font-semibold uppercase tracking-[0.08em] text-white/40">
          Em desenvolvimento
        </p>
        {futureNavItems.map((item) => {
          const Icon = item.icon;
          return (
            <div
              key={item.label}
              className="group relative flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium text-white/30 cursor-not-allowed select-none"
            >
              <Icon className="size-5 shrink-0" />
              <span>{item.label}</span>
              {item.badge && (
                <span className="ml-auto rounded-full bg-white/10 px-2 py-0.5 text-[10px] font-medium text-white/40">
                  {item.badge}
                </span>
              )}
            </div>
          );
        })}
      </div>
    </nav>
  );
}

export function Sidebar() {
  return (
    <>
      {/* Desktop sidebar */}
      <aside className="hidden lg:flex lg:flex-col lg:w-60 lg:shrink-0 bg-grafite h-screen sticky top-0">
        <SidebarContent />
      </aside>
    </>
  );
}

export function MobileSidebar() {
  return (
    <Sheet>
      <SheetTrigger
        className="lg:hidden inline-flex items-center justify-center size-8 rounded-lg text-grafite hover:bg-muted transition-colors"
        aria-label="Abrir menu"
      >
        <Menu className="size-5" />
      </SheetTrigger>
      <SheetContent side="left" className="w-64 bg-grafite p-0 border-r-0">
        <SheetHeader className="sr-only">
          <SheetTitle>Menu de navegação</SheetTitle>
        </SheetHeader>
        <SidebarContent />
      </SheetContent>
    </Sheet>
  );
}

function SidebarContent() {
  return (
    <div className="flex h-full flex-col">
      {/* Logo */}
      <div className="flex items-center gap-3 px-6 pt-6 pb-5">
        <div className="flex size-9 items-center justify-center rounded-xl bg-menta shadow-md shadow-menta/25">
          <span className="text-sm font-heading font-bold text-white">U</span>
        </div>
        <div className="flex flex-col">
          <span className="text-base font-heading font-bold text-white tracking-tight">
            Base UNIQ
          </span>
          <span className="text-[11px] font-body text-white/50">
            Sua central digital
          </span>
        </div>
      </div>

      <Separator className="bg-white/10" />

      {/* Navigation */}
      <div className="flex-1 overflow-y-auto py-4">
        <SidebarNav />
      </div>

      {/* Footer */}
      <div className="border-t border-white/10 px-4 py-4">
        <p className="text-center text-[10px] text-white/30 font-body">
          &copy; 2026 UNIQ Consultoria
        </p>
      </div>
    </div>
  );
}
