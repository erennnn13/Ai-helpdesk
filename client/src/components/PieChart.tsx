export interface PieChartSegment {
  label: string;
  value: number;
  color: string;
  textColor?: string;
}

export interface PieChartProps {
  data: PieChartSegment[];
  size?: number;
  strokeWidth?: number;
  centerLabel?: string;
  centerValue?: string | number;
}

export function PieChart({
  data,
  size = 180,
  strokeWidth = 24,
  centerLabel = "Total",
  centerValue,
}: PieChartProps) {
  const total = data.reduce((sum, item) => sum + (item.value > 0 ? item.value : 0), 0);
  const radius = 50 - strokeWidth / 2;
  const circumference = 2 * Math.PI * radius;

  let cumulativePercent = 0;

  return (
    <div className="flex flex-col items-center justify-center p-2">
      <div className="relative" style={{ width: size, height: size }}>
        <svg
          viewBox="0 0 100 100"
          className="w-full h-full -rotate-90 transform overflow-visible"
        >
          {total === 0 ? (
            <circle
              cx="50"
              cy="50"
              r={radius}
              fill="none"
              stroke="currentColor"
              strokeWidth={strokeWidth}
              className="text-muted/20"
            />
          ) : (
            data.map((item, index) => {
              if (item.value <= 0) return null;
              const percent = item.value / total;
              const dasharray = `${percent * circumference} ${circumference}`;
              const dashoffset = -cumulativePercent * circumference;
              cumulativePercent += percent;

              return (
                <circle
                  key={index}
                  cx="50"
                  cy="50"
                  r={radius}
                  fill="none"
                  stroke={item.color}
                  strokeWidth={strokeWidth}
                  strokeDasharray={dasharray}
                  strokeDashoffset={dashoffset}
                  className="transition-all duration-500 ease-out hover:opacity-90 cursor-pointer"
                />
              );
            })
          )}
        </svg>

        {/* Center Content */}
        <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none text-center">
          <span className="text-xs font-medium text-muted-foreground">{centerLabel}</span>
          <span className="text-xl font-bold tracking-tight text-foreground">
            {centerValue !== undefined ? centerValue : total}
          </span>
        </div>
      </div>

      {/* Legend */}
      <div className="grid grid-cols-2 gap-x-4 gap-y-2 mt-4 w-full text-xs">
        {data.map((item, index) => {
          const percent = total > 0 ? Math.round((item.value / total) * 100) : 0;
          return (
            <div key={index} className="flex items-center gap-2 min-w-0">
              <span
                className="h-2.5 w-2.5 rounded-full shrink-0"
                style={{ backgroundColor: item.color }}
              />
              <span className="truncate text-muted-foreground font-medium">{item.label}</span>
              <span className="ml-auto font-semibold text-foreground">
                {item.value} ({percent}%)
              </span>
            </div>
          );
        })}
      </div>
    </div>
  );
}
