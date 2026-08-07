import { AppShell } from "@/components/layout/app-shell";
import { Header } from "@/components/layout/header";

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <AppShell header={<Header />}>
      {children}
    </AppShell>
  );
}
