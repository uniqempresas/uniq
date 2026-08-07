import { Sidebar } from "./sidebar";

interface AppShellProps {
  children: React.ReactNode;
  header?: React.ReactNode;
}

export function AppShell({ children, header }: AppShellProps) {
  return (
    <div className="flex min-h-screen bg-cinza-claro">
      {/* Sidebar - fixed on desktop */}
      <Sidebar />

      {/* Main area */}
      <div className="flex flex-1 flex-col min-w-0">
        {/* Header */}
        {header && <div>{header}</div>}

        {/* Content */}
        <main className="flex-1 overflow-auto">
          <div className="mx-auto w-full max-w-7xl px-4 py-6 sm:px-6 lg:px-8">
            {children}
          </div>
        </main>
      </div>
    </div>
  );
}
