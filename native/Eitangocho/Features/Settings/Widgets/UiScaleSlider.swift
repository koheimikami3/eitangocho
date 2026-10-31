#if os(macOS)
  import SwiftUI

  /// UI 全体の拡大率を 0.1 刻みで変えるスライダーの行(Flutter 版の UiScaleSlider)。変更は即保存・即反映。
  ///
  /// Flutter 版は Material の Slider をプロトタイプの意匠(トラック 4px・白いつまみ 17px)に
  /// 寄せたもので、Material 3(2023 年版)の既定のまま残る部分(つまみ側が 2px 太いトラック・
  /// 目盛りの点)も含めて同じ形に描く。
  struct UiScaleSlider: View {
    let value: Double
    let onChange: (Double) -> Void

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px
    /// ドラッグの開始時のトラック(ウィンドウの座標)。離すまでこれを基準に値を決める。
    @State private var dragTrack: DragTrack?

    private static let range = AppDimensions.minUiScale...AppDimensions.maxUiScale
    private static let divisions = Int(((range.upperBound - range.lowerBound) * 10).rounded())

    /// トラックの左端と幅(ウィンドウの座標)。
    private struct DragTrack {
      var minX: CGFloat
      var width: CGFloat
    }

    var body: some View {
      let clamped = min(max(value, Self.range.lowerBound), Self.range.upperBound)
      HStack(spacing: px(12)) {
        AppText(.uiScale, style: SettingsRowStyle.label)
          .foregroundStyle(colors.textPrimary)
        GeometryReader { geometry in
          track(width: geometry.size.width, value: clamped)
            .contentShape(Rectangle())
            // 値を変えると倍率で行の寸法と位置が変わるので、スライダー自身の座標で指の位置を読むと、
            // 指が止まっていても次のフレームで別の値になり、隣の値と往復し続ける。
            // ウィンドウの座標で指の位置を読み、トラックの位置と幅は開始時のものに固定して戻りを断つ。
            .gesture(
              DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .onChanged { drag in
                  let track = dragTrack ?? startTrack(in: geometry.frame(in: .global))
                  dragTrack = track
                  select((drag.location.x - track.minX) / track.width, current: clamped)
                }
                .onEnded { _ in dragTrack = nil })
        }
        .frame(height: px(26))
        AppText(String(format: "%.1fx", clamped), style: AppTextStyle(size: 12))
          .foregroundStyle(colors.textMuted)
          .frame(width: px(34), alignment: .trailing)
      }
      .padding(px(SettingsRowStyle.padding))
    }

    /// つまみの半径(Flutter 版の _CircleThumbShape)。トラックはこの分だけ両端を内側に寄せる。
    private var thumbRadius: CGFloat { px(8.5) }

    private func fraction(_ value: Double) -> CGFloat {
      CGFloat((value - Self.range.lowerBound) / (Self.range.upperBound - Self.range.lowerBound))
    }

    /// つまみの動く範囲(両端をつまみの半径だけ内側に寄せた所)。
    private func startTrack(in frame: CGRect) -> DragTrack {
      DragTrack(minX: frame.minX + thumbRadius, width: max(frame.width - thumbRadius * 2, 1))
    }

    /// トラック上の割合(0〜1 の外は端に寄せる)を 0.1 刻みの値にして、変わったときだけ知らせる。
    private func select(_ fraction: CGFloat, current: Double) {
      let t = min(max(fraction, 0), 1)
      let step = (Double(t) * Double(Self.divisions)).rounded()
      let selected = Self.range.lowerBound + step / 10
      if abs(selected - current) > 0.001 { onChange(selected) }
    }

    private func track(width: CGFloat, value: Double) -> some View {
      let left = thumbRadius
      let trackWidth = max(width - thumbRadius * 2, 0)
      let thumbX = left + fraction(value) * trackWidth
      let midY = px(13)
      let trackHeight = px(4)
      let tickRadius = trackHeight / 4
      return ZStack(alignment: .topLeading) {
        // つまみより左(到達側)は上下 1px ずつ太く、左端だけ丸める。
        UnevenRoundedRectangle(
          topLeadingRadius: trackHeight / 2 + px(1), bottomLeadingRadius: trackHeight / 2 + px(1)
        )
        .fill(colors.accent)
        .frame(width: max(thumbX - left, 0), height: trackHeight + px(2))
        .offset(x: left, y: midY - trackHeight / 2 - px(1))
        // 未到達側はプロトタイプの rgba(0,0,0,0.12)。右端だけ丸める。
        UnevenRoundedRectangle(bottomTrailingRadius: trackHeight / 2, topTrailingRadius: trackHeight / 2)
          .fill(colors.borderAlpha(12))
          .frame(width: max(left + trackWidth - thumbX, 0), height: trackHeight)
          .offset(x: thumbX, y: midY - trackHeight / 2)
        // 目盛り(Flutter の RoundSliderTickMarkShape。半径はトラックの高さの 1/4)。
        ForEach(0...Self.divisions, id: \.self) { index in
          let centerX = left + CGFloat(index) / CGFloat(Self.divisions) * (trackWidth - tickRadius * 2) + tickRadius
          Circle()
            .fill(
              (centerX > thumbX ? colors.materialOnSurfaceVariant : colors.materialOnPrimary).opacity(0.38))
            .frame(width: tickRadius * 2, height: tickRadius * 2)
            .offset(x: centerX - tickRadius, y: midY - tickRadius)
        }
        thumb
          .offset(x: thumbX - thumbRadius, y: midY - thumbRadius)
      }
      .frame(width: width, height: px(26), alignment: .topLeading)
    }

    /// プロトタイプのつまみ(17×17 の白い円・薄い枠線 + 影)。
    private var thumb: some View {
      ZStack {
        // 影: rgba(0,0,0,0.3) を 1px 下にずらしてぼかす(Flutter の MaskFilter.blur の sigma 1.5)。
        Circle()
          .fill(Color(argb: 0x4D00_0000))
          .offset(y: px(1))
          .blur(radius: px(1.5))
        Circle().fill(.white)
        Circle().stroke(Color(argb: 0x1F00_0000), lineWidth: px(0.5))
      }
      .frame(width: thumbRadius * 2, height: thumbRadius * 2)
    }
  }
#endif
