import SwiftUI

struct OnboardingView: View {
    @StateObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $viewModel.currentPage) {
                OnboardingPage(
                    systemImage: "map.fill",
                    title: "GoWhere",
                    description: "어디 갈지 고민될 때\n랜덤으로 장소를 추천해드려요"
                )
                .tag(0)

                OnboardingPage(
                    systemImage: "location.fill",
                    title: "도시 선택",
                    description: "원하는 도시를 선택하고\n추첨 버튼을 눌러보세요"
                )
                .tag(1)

                OnboardingPage(
                    systemImage: "fork.knife",
                    title: "맛집 찾기",
                    description: "추천받은 위치 주변의\n맛집을 바로 검색할 수 있어요"
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Spacer()
                .frame(height: 60)

            if viewModel.currentPage < 2 {
                Button(action: viewModel.nextPage) {
                    Text("다음")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.blue)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            } else {
                Button(action: viewModel.complete) {
                    Text("시작하기")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.blue)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPage: View {
    let systemImage: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: systemImage)
                .font(.system(size: 100))
                .foregroundColor(.blue)

            VStack(spacing: 12) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Spacer()
        }
        .padding()
    }
}
